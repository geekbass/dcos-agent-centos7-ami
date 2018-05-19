#!groovy

node {

  def err = null
  def environment = "Development"
  currentBuild.result = "SUCCESS"

  try {
    stage ('Checkout') {
      checkout scm
    }
    
    /* Show Version so we know if we need to update or not */
    stage ('Version') {
      sh """
       set +x
       packer version
       """
    } 

    /* If Validation fails, Pipeline fails. See Console for errors */
    stage ('Validate') {
      sh """
       set +x
       packer validate dcos_agent_centos7.4.json
       """
    }
    
    /* Build if validation passes */
    stage ('Build') {
      withCredentials([string(credentialsId: 'aws-access-key', variable: 'AWS_ACCESS_KEY_ID'), 
                       string(credentialsId: 'aws-secret-key', variable: 'AWS_SECRET_ACCESS_KEY')]) {
        sh """
         set +x
         packer build -var aws_access_key=${AWS_ACCESS_KEY_ID} -var aws_secret_key=${AWS_SECRET_ACCESS_KEY} dcos_agent_centos7.4.json
         """
        }  
    }

    stage ('Notify') {
      mail from: "email@email.com",
           to: "email@email.com",
           subject: "Packer Build for ${environment} Complete.",
           body: "Jenkins Job ${env.JOB_NAME} - build  ${env.BUILD_NUMBER} for ${environment}. Please investigate."
    }
  }

  catch (caughtError) {
    err = caughtError
    currentBuild.result = "FAILURE"
  }

  finally {
    /* Must re-throw exception to propagate error */
    if (err) {
      throw err
    }
  }
}