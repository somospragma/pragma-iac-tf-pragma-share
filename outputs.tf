##############################################################
# Outputs
#
# El nombre del output (en MAYÚSCULAS) ES el nombre de la variable que
# el pipeline publica en la library. El template ya no antepone TF_VAR_,
# así que:  output "ecs_cluster"  ->  variable ECS_CLUSTER
#
# Solo se expone el nombre del cluster ECS, que alimenta ECS_CLUSTER en la
# library del micro (pragma-ms-java-pragma-transfer).
#
# ECS_SERVICE y SECRET_APIS_NAME NO salen de aquí: se crean en la capa de
# funcionalidad (core) y se publican desde ahí.
##############################################################
output "ecs_cluster" {
  description = "Nombre del cluster ECS compartido — publica la variable ECS_CLUSTER en la library del micro"
  value       = length(var.ecs_cluster_config) > 0 ? values(module.ecs_cluster.cluster_info)[0].cluster_name : ""
}
