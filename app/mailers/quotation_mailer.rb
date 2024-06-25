class QuotationMailer < ApplicationMailer
  def send_quotation_details(quotation, admin, pdf_file, recipient_email)
    @quotation = quotation
    @admin = admin
    @quotation_items = @quotation.quotation_items.includes(:product)

    attachments['quotation.pdf'] = {
      mime_type: 'application/pdf',
      content: pdf_file
    }

    mail(to: recipient_email, subject: 'Your Quotation Details')
  end
end
