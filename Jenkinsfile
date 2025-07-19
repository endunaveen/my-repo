pipeline {
    agent any

    environment {
        AWS_REGION = 'ap-south-1'
        TF_VAR_key_name = 'your-key-name'
    }

    stages {
        stage('Checkout') {
            steps {
                git 'https://github.com/endunaveen/my-repo.git'
            }
        }

        stage('Terraform Init & Apply') {
            steps {
                dir('terraform') {
                    sh 'terraform init'
                    sh 'terraform apply -auto-approve'
                }
            }
        }

        stage('Get Public IP') {
            steps {
                script {
                    def ec2Ip = sh(script: "cd terraform && terraform output -raw ec2_public_ip", returnStdout: true).trim()
                    env.APP_EC2_IP = ec2Ip
                }
            }
        }

        stage('Install Kubernetes + Helm') {
            steps {
                sshagent(['ec2-key']) {
                    sh '''
                    ssh -o StrictHostKeyChecking=no ubuntu@$APP_EC2_IP << EOF
                        sudo apt update
                        sudo snap install helm --classic
                        curl -LO "https://dl.k8s.io/release/v1.29.2/bin/linux/amd64/kubectl"
                        chmod +x kubectl && sudo mv kubectl /usr/local/bin/
                        curl -LO https://kind.sigs.k8s.io/dl/latest/kind-linux-amd64
                        chmod +x kind-linux-amd64 && sudo mv kind-linux-amd64 /usr/local/bin/kind
                        kind create cluster
                    EOF
                    '''
                }
            }
        }

        stage('Deploy App with Helm') {
            steps {
                sshagent(['ec2-key']) {
                    sh '''
                    ssh ubuntu@$APP_EC2_IP << EOF
                        helm repo add bitnami https://charts.bitnami.com/bitnami
                        helm install my-nginx bitnami/nginx
                    EOF
                    '''
                }
            }
        }
    }

    post {
        always {
            echo "Pipeline Completed!"
        }
    }
}
