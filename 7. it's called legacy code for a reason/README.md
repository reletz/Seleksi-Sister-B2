# It’s Called ‘Legacy Code’ for a Reason

## 1. Completed Bonus Tasks

| No. | Bonus Name                      | Points | Status  | Description                                                                                                      |
| --- | ------------------------------- | ------ | ------- | ---------------------------------------------------------------------------------------------------------------- |
| 1   | Conversion to Indonesian Rupiah | 2      | ✅ Done | Account balance is now displayed in Rupiah (IDR) using the suggested rate (1 Rai Stone ≈ Rp 120,000,000).        |
| 2   | Deploy using Kubernetes         | 3      | ✅ Done | The application has been successfully deployed to a Kubernetes (k3s) cluster on a DigitalOcean VPS.              |
| 3   | Add Reverse Proxy               | 2      | ✅ Done | An NGINX reverse proxy has been deployed in the cluster to handle incoming traffic before forwarding to the app. |

## 2. How It Works

This project consists of a COBOL backend exposed via API using FastAPI (Python). The entire application is containerized with Docker and deployed to a Kubernetes cluster.

### Deployment Architecture

The deployed application workflow is as follows:

1. **User Request:** User accesses http://138.68.59.2:30008.
2. **Kubernetes Service (NodePort):** Requests enter the Kubernetes cluster via the NodePort exposed by the NGINX Service.
3. **Reverse Proxy (NGINX):** The service forwards requests to the NGINX Pod, which acts as a reverse proxy and forwards traffic to the internal COBOL app service.
4. **COBOL Application:** The `cobol-banking-service` receives requests and sends them to the COBOL/FastAPI app Pod for execution.
5. **Response:** The COBOL program's result is returned through the same path back to the user.

### Running the Project from Scratch

#### A. Local Preparation and Build

**Prerequisite:** Docker must be installed on your computer.

1. **Build Docker Image:** Open a terminal in the project directory and build the app image:

- See: [Dockerfile](Dockerfile)

2. **Push Image to Registry:** To allow Kubernetes to access it, push the image to a registry like Docker Hub.

- See: [Dockerfile](Dockerfile)

#### B. Deploy to Kubernetes

**Prerequisites:**

- A running Kubernetes cluster (this project uses k3s on a VPS).
- `kubectl` on your local machine configured to connect to the cluster.
- The server firewall allows incoming traffic on port 30008.

1. **Apply Manifest:** All Kubernetes configuration (Deployment, Service, ConfigMap) is combined in one file: [deployment.yaml](deployment.yaml)

- Run: `kubectl apply -f deployment.yaml`

2. **Verify and Access:**

- Wait about a minute, then check all pods are running with `kubectl get pods`. You should see two pods (`cobol-banking-app-...` and `nginx-reverse-proxy-...`) with status Running.
- The app is publicly accessible at http://138.68.59.2:30008.

## 3. Source Code
.
├── accounts.txt
├── app.py
├── deployment.yaml
├── Dockerfile
├── index.html
├── input.txt
├── main.cob
├── nginx.conf
├── output.txt
├── README.md
└── requirements.txt

Please refer to the respective files for the full code and configuration details.

## 4. Credits
Credits to Gemini who guides me into deploying into kubernetes
Also, credits to Riko for teaching me to make it a secure HTTPS (I failed bruh)
