class Notifier < ActionMailer::Base
  default :from => "sites@gk-gorchakov.ru",
	  :return_path => "sites@gk-gorchakov.ru"
  def notify_new_register(client)
    @about=client
    mail(:to =>"admin@mirpoz.ru",:subject =>"Зарегистрировался новый пользователь" )
  end
  def notify_new_order(order)
    @about=order.client
    @order=order
    attachments['order.xml'] = order.xml
    mail(:to =>"admin@mirpoz.ru",:subject =>"Новый заказ на сайте "+order.site.name )
  end  
end
