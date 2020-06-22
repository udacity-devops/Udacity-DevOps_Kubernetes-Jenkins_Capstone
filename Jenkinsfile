pipeline {
	environment {
		registry = "edunicastro/capstone"
		registryCredential = 'dockerhub_id'
		dockerImage = ''
	}
	agent any
	stages {
		stage('Lint HTML') {
			steps {
			    sh 'tidy -q -e *.html'
			}
		}
		
		stage('Build Docker Image') {
			steps {
				script {
					dockerImage = docker.build registry + ":$BUILD_NUMBER"
				}
			}
		}

		stage('Push Image To Dockerhub') {
			steps {
				script {
					docker.withRegistry( '', registryCredential ) {
						dockerImage.push()
					}
				}
			}
		}

		stage('Set current kubectl context') {
			steps {
				withAWS(region:'us-east-2', credentials:'aws-static') {
					sh '''
						kubectl config use-context arn:aws:eks:us-east-2:619840106163:cluster/capstonecluster
					'''
				}
			}
		}

		stage('Deploy blue container') {
			steps {
				withAWS(region:'us-east-2', credentials:'aws-static') {
    				sh '''
    				    sed "s/capstone\"/capstone:${BUILD_NUMBER}\"/g" ./blue-controller.json | kubectl apply -f -
    				'''
				}
			}
		}

		stage('Deploy green container') {
			steps {
				withAWS(region:'us-east-2', credentials:'aws-static') {
					sh '''
						sed "s/capstone\"/capstone:${BUILD_NUMBER}\"/g" ./green-controller.json | kubectl apply -f -
					'''
				}
			}
		}

		stage('Create the service in the cluster, redirect to blue') {
			steps {
				withAWS(region:'us-east-2', credentials:'aws-static') {
					sh '''
						kubectl apply -f ./blue-service.json
					'''
				}
			}
		}

		stage('Wait user approve: redirect to green') {
            steps {
                input "Ready to redirect traffic to green?"
            }
        }

		stage('Create the service in the cluster, redirect to green') {
			steps {
				withAWS(region:'us-east-2', credentials:'aws-static') {
					sh '''
						kubectl apply -f ./green-service.json
						kubectl delete -f blue-controller.json
						sed "s/capstone\"/capstone:${BUILD_NUMBER}\"/g" ./blue-controller.json | kubectl apply -f -
					'''
				}
			}
		}
		stage('Wait user approve: deploy and redirect back to blue') {
			steps {
        		input "Finish deploying new version to Blue ?"
    		}
		}
        stage('Redirect to blue and clean up') {
			steps {
				withAWS(region:'us-east-2', credentials:'aws-static') {
					sh '''
						kubectl apply -f ./blue-service.json
						kubectl delete -f green-controller.json
					'''
				}
			}
		}
	}
}
