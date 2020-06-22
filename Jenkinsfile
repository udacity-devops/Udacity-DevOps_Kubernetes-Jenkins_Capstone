pipeline {
	agent any
	stages {

		stage('Create kubernetes cluster') {
			steps {
				withAWS(region:'us-east-2',credentials:'aws-static') {
					sh '''
						eksctl create cluster \
						--name capstonecluster \
						--version 1.16 \
						--region us-east-2 \
						--nodegroup-name standard-workers \
						--node-type t2.micro \
						--nodes 2 \
						--nodes-min 1 \
						--nodes-max 2 \
						--managed
					'''
				}
			}
		}

		

		stage('Create conf file cluster') {
			steps {
				withAWS(region:'us-east-2', credentials:'aws-static') {
					sh '''
						aws eks --region us-east-2 update-kubeconfig --name capstonecluster
					'''
				}
			}
		}

	}
}
