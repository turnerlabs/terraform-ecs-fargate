/**
 * This module creates a CloudWatch dashboard for you app,
 * showing its CPU and memory utilization and various HTTP-related metrics.
 *
 * The graphs of HTTP requests are stacked.  Green indicates successful hits
 * (HTTP response codes 2xx), yellow is used for client errors (HTTP response
 * codes 4xx) and red is used for server errors (HTTP response codes 5xx).
 * Stacking is used because, when things are running smoothly, those graphs
 * will be predominately green, making the dashboard easier to check
 * at a glance or at a distance.
 *
 * One of the graphs shows HTTP response codes returned by your containers.
 * Another graph shows HTTP response codes returned by your load balancer.
 * Although these two graphs often look very similar, there are situations
 * where they will differ.
 * If your containers are responding 200 OK but are taking too long to
 * respond, the load balancer will return 504 Gateway Timeout.  In that
 * case, the containers' graph could show green while the load balancer's
 * graph shows red.
 * If many of your containers are failing their healthchecks, the load
 * balancer will direct traffic to the healthy containers.  In that case,
 * the load balancer's graph could show green while the containers'
 * graph shows red.
 * The containers' graph might show more traffic than the load balancer's.
 * Some of the containers' traffic is due to the healthchecks, which
 * originate with the load balancer.  Also, it is possible that future
 * load balancers will re-attempt HTTP requests that the HTTP standard
 * declares idempotent.
 *
 */

resource "aws_cloudwatch_dashboard" "cloudwatch_dashboard" {
  dashboard_name = "${var.app}-${var.environment}-fargate"

  dashboard_body = <<EOF
{"widgets":[{"type":"metric","x":12,"y":6,"width":12,"height":6,"properties":{"view":"timeSeries","stacked":false,"metrics":[["AWS/ECS","MemoryUtilization","ServiceName","${var.app}-${var.environment}","ClusterName","${var.app}-${var.environment}",{"color":"#1f77b4"}],[".","CPUUtilization",".",".",".",".",{"color":"#9467bd"}]],"region":"us-east-1","period":300,"title":"Memory and CPU utilization","yAxis":{"left":{"min":0,"max":100}}}},{"type":"metric","x":0,"y":6,"width":12,"height":6,"properties":{"view":"timeSeries","stacked":true,"metrics":[["AWS/ApplicationELB","HTTPCode_Target_5XX_Count","TargetGroup","${aws_alb_target_group.main.arn_suffix}","LoadBalancer","${aws_alb.main.arn_suffix}",{"period":60,"color":"#d62728","stat":"Sum"}],[".","HTTPCode_Target_4XX_Count",".",".",".",".",{"period":60,"stat":"Sum","color":"#bcbd22"}],[".","HTTPCode_Target_3XX_Count",".",".",".",".",{"period":60,"stat":"Sum","color":"#98df8a"}],[".","HTTPCode_Target_2XX_Count",".",".",".",".",{"period":60,"stat":"Sum","color":"#2ca02c"}]],"region":"us-east-1","title":"Container responses","period":300,"yAxis":{"left":{"min":0}}}},{"type":"metric","x":12,"y":0,"width":12,"height":6,"properties":{"view":"timeSeries","stacked":false,"metrics":[["AWS/ApplicationELB","TargetResponseTime","LoadBalancer","${aws_alb.main.arn_suffix}",{"period":60,"stat":"p50"}],["...",{"period":60,"stat":"p90","color":"#c5b0d5"}],["...",{"period":60,"stat":"p99","color":"#dbdb8d"}]],"region":"us-east-1","period":300,"yAxis":{"left":{"min":0,"max":3}},"title":"Container response times"}},{"type":"metric","x":12,"y":12,"width":12,"height":2,"properties":{"view":"singleValue","metrics":[["AWS/ApplicationELB","HealthyHostCount","TargetGroup","${aws_alb_target_group.main.arn_suffix}","LoadBalancer","${aws_alb.main.arn_suffix}",{"color":"#2ca02c","period":60}],[".","UnHealthyHostCount",".",".",".",".",{"color":"#d62728","period":60}]],"region":"us-east-1","period":300,"stacked":false}},{"type":"metric","x":0,"y":0,"width":12,"height":6,"properties":{"view":"timeSeries","stacked":true,"metrics":[["AWS/ApplicationELB","HTTPCode_Target_5XX_Count","LoadBalancer","${aws_alb.main.arn_suffix}",{"period":60,"stat":"Sum","color":"#d62728"}],[".","HTTPCode_Target_4XX_Count",".",".",{"period":60,"stat":"Sum","color":"#bcbd22"}],[".","HTTPCode_Target_3XX_Count",".",".",{"period":60,"stat":"Sum","color":"#98df8a"}],[".","HTTPCode_Target_2XX_Count",".",".",{"period":60,"stat":"Sum","color":"#2ca02c"}]],"region":"us-east-1","title":"Load balancer responses","period":300,"yAxis":{"left":{"min":0}}}}]}
EOF
}
