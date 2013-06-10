class Notifier < ActionMailer::Base
  default :from => "sites@gk-gorchakov.ru",
	  :return_path => "sites@gk-gorchakov.ru"
  def notify_new_register(client)
    @about=client
    to_to=client.site.reg_emails
    mail(:to =>to_to , :subject =>"Зарегистрировался новый пользователь на сайте: " + client.site.address )
  end
  def notify_new_order(order,my_logger)
    @about=order.client
    @order=order
    to_to=order.site.orders_emails
    attachments[order.site.name+order.number+'.xml'] = order.xml
    mail(:to =>to_to , :subject =>"Новый заказ на сайте " + order.site.name )
  end  
end
