###############################################################################
# Main
#

## Locals =====================================================================
locals {
  common_tags = {
    service = var.subdomain
  }
  lambda_function_name = aws_lambda_function.contact_form.function_name
  apigateway_url       = aws_apigatewayv2_api.lambda_contact_form.api_endpoint
  lambda_s3_object_key = "contact_form_handler.zip"
  email_headers = {
    default_recipient = "form@${var.root_domain}"
    default_sender    = "form@${var.subdomain}"
  }
}

## Data =======================================================================
data "aws_caller_identity" "current" {}

data "aws_region" "current" {}
