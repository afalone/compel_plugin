module MailerExtension
 def self.included(base)
  #base.extend(IssueExtension::ClassMethods)
  base.send(:include, MailerExtension::InstanceMethods)
  base.class_eval do
   alias_method_chain :mail, :compel
   #alias_method_chain :render_multipart, :compel
  end
 end

 module InstanceMethods
  def mail_with_compel(headers = {})
   # compel
   if recipients
    recipients.reject do |user_email|
     user = User.find_by_mail(user_email)
     user and user.pref[:sms_notification]
    end
   end

   if cc
    cc.reject do |user_email|
     user = User.find_by_mail(user_email)
     user and user.pref[:sms_notification]
    end
   end

   if bcc
    bcc.reject do |user_email|
     user = User.find_by_mail(user_email)
     user and user.pref[:sms_notification]
    end
   end
   mail_without_compel(headers)
  end

  def render_multipart_with_compel(method_name, body)
   # compel
   content_type "text/plain"
   msg = subject + "\n\n" + render(:file => "#{method_name}.text.plain.rhtml", :body => body, :layout => 'mailer.text.plain.erb')
   portal_recipients = recipients
   portal_recipients << cc if cc
   portal_recipients << bcc if bcc
   portal_recipients.uniq.each do |m|
#         PortalMessage.create_and_send_for_email(m, msg)
    recipient_user = User.find_by_mail(m)
    if recipient_user && recipient_user.pref[:sms_notification]
     RestClient.post('http://www.rbagroup.ru:7777/', {:email => m, :message => msg }) rescue nil
    end
   end
   render_multipart_without_compel(method_name, body)
  end

 end
end
