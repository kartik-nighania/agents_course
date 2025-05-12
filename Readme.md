Core AWS Services Required
EC2: For running agent API services. 

VM with 4 core and x86 architecture. t3.xlarge preferred

Ubuntu 24.04 LTS OS image

Root user permission to install packages

internet access to download packages

Public subnet to deploy service over the internet

SSH access over port 22

CloudWatch: For log monitoring

IAM user: permission to:

Login via UI

EC2 access

cloudwatch access

External Services
OpenAI API key: as the LLM provider

LangSmith: any account to sign-up to LangSmith

EC2 with network access to:

openai.com

langchain.com

docker.com

pypi.org

ubuntu.com

github.com

