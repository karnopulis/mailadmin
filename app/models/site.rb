class Site < ActiveRecord::Base
   attr_accessible :name, :address, :login, :pass, :current_client, :current_order, :reg_emails, :orders_emails
   has_many :clients
   has_many :orders
   def import_clients(my_logger)
      load_xml_from('clients',my_logger).select{|cl| cl['id']> current_client }.sort_by{|cl| cl['id']}.each{ |cl|
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
         my_logger.warn("import_clients +New client:" + cl['id'].to_s)
      }
      return nil
   end
   def import_orders(my_logger)
      load_xml_from('orders',my_logger).select{|od| od['id']> current_order }.sort_by{|od| od['id']}.each{ |od|
         attrs = {'id' => od['id'],
                  'number' => od['number'],
                  'xml' => od.to_xml,
                  'site_id' =>self.id}
         od=clients.find(od['client']['id']).orders.new(attrs)
         od.new_record? ? od.update_attributes(attrs) : od.create(attrs)
         self.current_order = od['id']
         self.save
         my_logger.warn("import_orders+New order:" + od['id'].to_s)

      }
      return nil
   end
   def load_xml_from( resource,my_logger )
      h = []
      require 'net/http'
      i=1
      loop do        
         uri = URI.parse('http://'+address+'/admin/'+resource+'.xml?page='+i.to_s)
         #my_logger.warn( "load_xml_from "+ uri.to_s )
         r=get_responce_from_insales(uri,my_logger) 
         break if r == nil
         h=h +r[resource]
         i=i+1
      end
      return h
   end
   def check_and_send_emails(ser,my_logger)
      ser.where( "delivered=?",false).each { |se|
      begin
         if se.send_mail(my_logger)
            se.class.to_s
            my_logger.warn( "mail was sent for "+se.class.to_s+" id: "+se.id.to_s )
            se.delivered= true
            se.save
         end
      rescue Net::SMTPFatalError => e
         my_logger.warn("check_and_send_emails")
         my_logger.warn(Time.now)
         my_logger.warn(e.message)
         my_logger.warn(e.to_s)
      end
      }
      return nil
   end
   
   def get_responce_from_insales (uri,my_logger)
      req = Net::HTTP::Get.new(uri.to_s)
      req.basic_auth login, pass
      begin
         response = Net::HTTP.start(uri.host,uri.port ) {|http|
            http.request(req)
            }
      rescue Exception => exc
         my_logger.warn("get_responce_from_insales" +exc.message)
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
         my_logger.warn(response.code + response.message)
         return nil
      end
      
   end
end 
class Client < ActiveRecord::Base
   attr_accessible :id, :name, :company, :phone, :email, :site_id, :delivered
   belongs_to :site
   has_many :orders
   def send_mail(my_logger)
      Notifier.notify_new_register(self).deliver
   end
end
class Order < ActiveRecord::Base
   attr_accessible :id, :number, :site_id, :client_id, :xml, :delivered
   belongs_to :site
   belongs_to :client
   def send_mail(my_logger)
      Notifier.notify_new_order(self,my_logger).deliver
   end
end