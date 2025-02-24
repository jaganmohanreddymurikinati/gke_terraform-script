


provider "kubernetes" {
  config_path = "~/.kube/config"
}

# # Zookeeper Deployment
resource "kubernetes_stateful_set" "zookeeper" {
  metadata {
    name = "zookeeper"
    labels = {
      app = "zookeeper"
    }
  }

  spec {
    service_name = "zookeeper"
    replicas = 1

    selector {
      match_labels = {
        app = "zookeeper"
      }
    }

    template {
      metadata {
        labels = {
          app = "zookeeper"
        }
      }

      spec {
        container {
          name  = "zookeeper"
          image = "jaganreddy931/cp-zookeeper:latest"
          port {
            container_port = 2181
          }
          env {
            name  = "ZOOKEEPER_CLIENT_PORT"
            value = "2181"
          }
        }
      }
    }
  }
}

# # Zookeeper Service
resource "kubernetes_service" "zookeeper" {
  metadata {
    name = "zookeeper"
  }

  spec {
    selector = {
      app = "zookeeper"
    }

    port {
      protocol    = "TCP"
      port        = 2181
      target_port = 2181
    }

    cluster_ip = "None"  # Headless service for Zookeeper
  }
}

# # Kafka Deployment
resource "kubernetes_stateful_set" "kafka" {
  metadata {
    name = "kafka"
    labels = {
      app = "kafka"
    }
  }

  spec {
    service_name = "kafka"
    replicas = 1

    selector {
      match_labels = {
        app = "kafka"
      }
    }

    template {
      metadata {
        labels = {
          app = "kafka"
        }
      }

      spec {
        container {
          name  = "kafka"
          image = "jaganreddy931/cp-kafka:latest"
          port {
            container_port = 9092
          }

          env {
            name  = "KAFKA_ZOOKEEPER_CONNECT"
            value = "zookeeper-0.zookeeper:2181"  # Ensure this is the correct Zookeeper service name
          }
          env {
            name  = "KAFKA_ADVERTISED_LISTENERS"
            value = "INSIDE://kafka-0.kafka:9092"  # Kafka service address
          }
          env {
            name  = "KAFKA_LISTENER_SECURITY_PROTOCOL"
            value = "INSIDE:PLAINTEXT"
          }
	  env {
	    name  = "KAFKA_LISTENER_SECURITY_PROTOCOL_MAP"
            value = "INSIDE:PLAINTEXT"
          }
	  env {
  	    name  = "ZOOKEEPER_CLIENT_PORT"
 	    value = "2181"
	  }
          env {
            name  = "KAFKA_LISTENERS"
	    value = "INSIDE://0.0.0.0:9092"
          }
          env {
            name  = "KAFKA_INTER_BROKER_LISTENER_NAME"
            value = "INSIDE"
          }
          env {
            name  = "KAFKA_LISTENER_PORT"
            value = "9092"
	  }

          resources {
            requests = {
              cpu    = "500m"
              memory = "1Gi"
            }
            limits = {
              cpu    = "1"
              memory = "2Gi"
            }
          }
        }
      }
    }
  }
}



# # Kafka Service
resource "kubernetes_service" "kafka" {
  metadata {
    name = "kafka"
  }

  spec {
    selector = {
      app = "kafka"
    }

    port {
      protocol    = "TCP"
      port        = 9092
      target_port = 9092
    }

    cluster_ip = "None"  # Headless service (no cluster IP)
  }
}

# # Python Script Deployment
resource "kubernetes_deployment" "python_script" {
  metadata {
    name = "python-script"
    labels = {
      app = "python-script"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "python-script"
      }
    }

    template {
      metadata {
        labels = {
          app = "python-script"
        }
      }

      spec {
        container {
          name  = "python-script"
          image = "jaganreddy931/kafka-python-scripts-python-script"
          port {
            container_port = 5000
          }
        }
      }
    }
  }
}


