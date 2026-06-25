locals {
  backend_address_pool_name      = "appGatewayBackendPool"
  http_setting_name              = "appGatewayBackendHttpSettings"
  listener_name                  = "appGatewayHttpListener"
  frontend_ip_configuration_name = "appGatewayFrontendIP"
  frontend_port_name             = "appGatewayFrontendPort"
  request_routing_rule_name      = "appGatewayRoutingRule"
}
