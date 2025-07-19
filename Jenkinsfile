pipeline {
    agent any

    environment {
        AWS_REGION = 'ap-south-1'
    }

    stages {
        stage('Checkout') {
            steps {
                git 'https://github.com/endunaveen/my-repo.git'
            }
        }

        stage('Terraform Init') {
            steps {
                dir('terraform') {
                    sh 'terraform init'
                }
            }
        }

        stage('Terraform Apply') {
            steps {
                dir('terraform') {
                    withCredentials([usernamePassword(credentialsId: 'aws-creds', usernameVariable: 'AWS_ACCESS_KEY_ID', passwordVariable: 'AWS_SECRET_ACCESS_KEY')]) {
                        sh '''
                            terraform plan -out=tfplan
                            terraform apply -auto-approve tfplan
                        '''
                    }
                }
            }
        }

        stage('Get EC2 IP') {
            steps {
                script {
                    def ec2Ip = sh(script: "cd terraform && terraform output -raw ec2_2_public_ip", returnStdout: true).trim()
                    env.APP_IP = ec2Ip
                    echo "✅ EC2 IP: ${APP_IP}"
                }
            }
        }

        stage('Install Kind & Deploy Tomcat') {
            steps {
                sshagent (credentials: ['login1-key']) {
  sh """
    ssh -o StrictHostKeyChecking=no ubuntu@${APP_IP} << 'EOF'
      

      echo "Installing dependencies..."
      sudo apt update -y
      sudo apt install -y docker.io curl

      echo "Installing Kind..."
      curl -Lo kind https://kind.sigs.k8s.io/dl/v0.20.0/kind-linux-amd64
      chmod +x kind
      sudo mv kind /usr/local/bin/

      echo "Installing kubectl..."
      curl -LO "https://dl.k8s.io/release/v1.29.2/bin/linux/amd64/kubectl"
      chmod +x kubectl
      sudo mv kubectl /usr/local/bin/kubectl

      echo "Installing Helm..."
      curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

      echo "Creating Kind cluster..."
      sudo kind create cluster --name tomcat-cluster

      echo "Listing Kubernetes nodes:"
      
                        

                        echo "Creating directory and file..."
                        mkdir -p /opt/test-dir
                        echo hello > /opt/test-dir/test.txt
                        cat /opt/test-dir/test.txt

                        echo "Deploying sample app..."
                        helm repo add bitnami https://charts.bitnami.com/bitnami
                        helm repo update
                        helm install nginx bitnami/nginx --set service.type=NodePort

                        echo "✅ Done!"

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
