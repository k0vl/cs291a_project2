docker build -t us.gcr.io/cs291-f19/project2_$Env:CS291_ACCOUNT .

# docker run -it --rm `
#   -p 3000:3000 `
#   -v C:/Users/KarlWang/Documents/GitHub/cs291a_project2/application_default_credentials.json:/root/.config/gcloud/application_default_credentials.json `
#   us.gcr.io/cs291-f19/project2_$Env:CS291_ACCOUNT

docker run -it --rm `
  -p 3000:3000 `
   us.gcr.io/cs291-f19/project2_$Env:CS291_ACCOUNT