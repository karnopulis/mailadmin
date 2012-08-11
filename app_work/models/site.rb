class Site < ActiveRecord::Base
   attr_accessible :name, :address, :login, :pass, :current_client, :current_order
   has_many :clients
   has_many :orders
   def import_clients
      load_xml_from('clients').select{|cl| cl['id']> current_client }.sort_by{|cl| cl['id']}.each{ |cl|
         field_name="Организация"
         field_object = cl['fields_values'].select{|fv| fv['name']== field_name }.first
         attrs = {'id' => cl['id'],
                  'name' => cl['name'],
                  'phone' => cl['phone'],
                  'email' => cl['email'],
                  'company' => field_object ? field_object['value'] : nil  }
         cn=clients.new(attrs)
         cn.new_record? ? cn.update_attributes(attrs) : cn.create(attrs)
         self.current_client = cl['id']
         self.save
      }
      return nil
   end
   def import_orders
      load_xml_from('orders').select{|od| od['id']> current_order }.sort_by{|od| od['id']}.each{ |od|
         attrs = {'id' => od['id'],
                  'number' => od['number'],
                  'xml' => od.to_xml,
                  'site_id' =>self.id}
         od=clients.find(od['client']['id']).orders.new(attrs)
         od.new_record? ? od.update_attributes(attrs) : od.create(attrs)
         self.current_order = od['id']
         self.save
      }
      return nil
   end
   def load_xml_from( resource )
      h = []
      require 'net/http'
      i=1
      loop do        
         uri = URI.parse('http://'+address+'/admin/'+resource+'.xml?page='+i.to_s)
         print uri
         r=get_responce_from_insales(uri) 
         break if r == nil
         h=h +r[resource]
         i=i+1
      end
      return h
   end
   def check_and_send_emails(ser)
      ser.where( "delivered=?",false).each { |se|
      begin
         if se.send_mail
            se.class.to_s
            warn ( "mail was sent for "+se.class.to_s+" id: "+se.id.to_s )
            se.delivered= true
            se.save
         end
      rescue Exception => exc
         warn(exc.message)
      end
      }
      return nil
   end
   
   def get_responce_from_insales (uri)
      req = Net::HTTP::Get.new(uri.to_s)
      req.basic_auth login, pass
      begin
         response = Net::HTTP.start(uri.host,uri.port ) {|http|
            http.request(req)
            }
      rescue Exception => exc
         warn(exc.message)
         return nil
      end
      case response
      when Net::HTTPOK
         h=Hash.from_xml(response.body)
         if h["nil_classes"]
            return nil
         else
            return h
         end
      when Net::HTTPClientError, Net::HTTPInternalServerError
         warn(response.code + response.message)
         return nil
      end
      
   end
end 
class Client < ActiveRecord::Base
   attr_accessible :id, :name, :company, :phone, :email, :site_id, :delivered
   belongs_to :site
   has_many :orders
   def send_mail
      Notifier.notify_new_register(self).deliver
   end
end
class Order < ActiveRecord::Base
   attr_accessible :id, :number, :site_id, :client_id, :xml, :delivered
   belongs_to :site
   belongs_to :client
   def send_mail
      Notifier.notify_new_order(self).deliver
   end
end