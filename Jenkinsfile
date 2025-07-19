pipeline {
    agent any

    environment {
        AWS_REGION = 'ap-south-1'
    }

    stages {
        stage('Checkout Code') {
            steps {
                git 'https://github.com/endunaveen/my-repo.git'
            }
        }

        stage('Terraform Init & Apply') {
            steps {
                dir('terraform') {
                    sh 'terraform init'
                    sh 'terraform plan’
                    sh 'terraform apply -auto-approve'
                }
            }
        }

        stage('Get EC2 IP') {
            steps {
                script {
                    def ec2Ip = sh(script: "cd terraform && terraform output -raw ec2_public_ip", returnStdout: true).trim()
                    env.APP_IP = ec2Ip
                    echo "✅ EC2 IP: ${APP_IP}"
                }
            }
        }

        stage('Install Kind & Deploy Tomcat') {
            steps {
                sshagent(credentials: ['ec2-2-key']) {
                    sh """
                    ssh -o StrictHostKeyChecking=no ubuntu@${APP_IP} << 'EOF'
                      sudo apt update -y
                      sudo apt install -y docker.io curl

                      # Install Kind
                      curl -Lo kind https://kind.sigs.k8s.io/dl/v0.20.0/kind-linux-amd64
                      chmod +x kind && sudo mv kind /usr/local/bin/

                      # Install kubectl
                      curl -LO "https://dl.k8s.io/release/v1.29.2/bin/linux/amd64/kubectl"
                      chmod +x kubectl && sudo mv kubectl /usr/local/bin/kubectl

                      # Install Helm
                      curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

                      # Start Kind cluster
                      kind create cluster --name tomcat-cluster

                      # Deploy Tomcat using Helm
                      helm repo add bitnami https://charts.bitnami.com/bitnami
                      helm install tomcat bitnami/tomcat --set service.type=NodePort

                      echo "🎉 Tomcat deployed successfully on Kind!"
                    EOF
                    """
                }
            }
        }
    }

    post {
        always {
            echo '📦 Pipeline completed'
        }
    }
}
