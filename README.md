# ToggleMaster - Infraestrutura Azure (Terraform)

Infraestrutura como código para a plataforma ToggleMaster, provisionando todos os recursos necessários na Azure.

## Arquitetura

```
┌─────────────────────────────────────────────────────────┐
│                   Resource Group                        │
│                  rg-togglemaster-prod                    │
│                                                         │
│  ┌──────────┐   ┌──────────────────────────────────┐    │
│  │   ACR    │   │          VNet 10.0.0.0/16        │    │
│  │  Basic   │   │  ┌───────────────────────────┐   │    │
│  │  admin   │◄──│  │  Subnet AKS 10.0.0.0/20  │   │    │
│  │ enabled  │   │  │  ┌─────────────────────┐  │   │    │
│  └──────────┘   │  │  │    AKS Cluster      │  │   │    │
│                 │  │  │  2-4 nodes (B2s)     │  │   │    │
│                 │  │  │  Calico CNI          │  │   │    │
│                 │  │  │  ┌───────────────┐   │  │   │    │
│                 │  │  │  │ ArgoCD (Helm) │   │  │   │    │
│                 │  │  │  └───────────────┘   │  │   │    │
│                 │  │  └─────────────────────┘  │   │    │
│                 │  └───────────────────────────┘   │    │
│                 └──────────────────────────────────┘    │
│                                                         │
│  ┌──────────────────────────────────────────────────┐   │
│  │         Recursos opcionais (deploy_databases)    │   │
│  │  PostgreSQL (auth, flags, targeting)             │   │
│  │  Redis Cache │ Service Bus │ Cosmos DB           │   │
│  └──────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────┘
```

## Recursos provisionados

| Recurso | Tipo | Descrição |
|---------|------|-----------|
| Resource Group | `azurerm_resource_group` | Agrupamento de todos os recursos |
| VNet | `azurerm_virtual_network` | Rede virtual (10.0.0.0/16) |
| Subnet | `azurerm_subnet` | Sub-rede para AKS (10.0.0.0/20) |
| AKS | `azurerm_kubernetes_cluster` | Cluster Kubernetes (2-4 nodes, autoscaling) |
| ACR | `azurerm_container_registry` | Container Registry com admin habilitado |
| ArgoCD | `helm_release` | GitOps controller instalado via Helm |
| PostgreSQL* | `azurerm_postgresql_flexible_server` | Bancos: auth, flags, targeting |
| Redis* | `azurerm_redis_cache` | Cache compartilhado |
| Service Bus* | `azurerm_servicebus_namespace` | Fila de eventos de avaliação |
| Cosmos DB* | `azurerm_cosmosdb_account` | Armazenamento de eventos (Table API) |

> *Recursos opcionais — provisionados apenas quando `deploy_databases = true`

## Pré-requisitos

- [Terraform](https://www.terraform.io/downloads) >= 1.5.0
- [Azure CLI](https://docs.microsoft.com/cli/azure/install-azure-cli) instalado e autenticado
- Subscription Azure ativa
- Storage Account para remote state já criado (`sttfstatebsouth`)

## Início rápido

### 1. Autenticar na Azure

```bash
az login
az account set --subscription "<SUBSCRIPTION_ID>"
```

### 2. Inicializar o Terraform

```bash
terraform init
```

### 3. Configurar variáveis

Crie o arquivo `terraform.tfvars`:

```hcl
subscription_id    = "<SUA_SUBSCRIPTION_ID>"
argocd_github_token = "<SEU_GITHUB_PAT>"

# Opcional: habilitar bancos de dados
# deploy_databases       = true
# postgres_admin_password = "senha-segura"
```

### 4. Aplicar a infraestrutura

```bash
terraform plan -out=tfplan
terraform apply tfplan
```

## Variáveis

| Variável | Tipo | Default | Descrição |
|----------|------|---------|-----------|
| `subscription_id` | string | - | Azure Subscription ID |
| `location` | string | `eastus` | Região Azure |
| `project_name` | string | `togglemaster` | Prefixo dos recursos |
| `environment` | string | `prod` | Nome do ambiente |
| `deploy_databases` | bool | `false` | Provisionar PostgreSQL, Redis, Service Bus e Cosmos DB |
| `aks_node_count` | number | `2` | Quantidade inicial de nodes |
| `aks_min_count` | number | `2` | Mínimo de nodes (autoscaling) |
| `aks_max_count` | number | `4` | Máximo de nodes (autoscaling) |
| `aks_vm_size` | string | `Standard_B2s` | Tamanho da VM dos nodes |
| `argocd_github_token` | string | - | PAT do GitHub para o ArgoCD |

## Remote State

O Terraform state é armazenado remotamente na Azure:

| Configuração | Valor |
|--------------|-------|
| Resource Group | `rg-production-storage-bsouth` |
| Storage Account | `sttfstatebsouth` |
| Container | `fiap` |
| State File | `togglemaster.tfstate` |

## Outputs

### Consultar todos os outputs

```bash
terraform output
```

### Consultar outputs sensíveis

```bash
terraform output -json
```

---

## Credenciais do ACR (Azure Container Registry)

O ACR é criado com `admin_enabled = true`, o que habilita autenticação via usuário e senha. Essas credenciais são necessárias para as pipelines CI/CD fazerem push de imagens.

### Via Terraform

```bash
# Username (é sempre o nome do ACR)
terraform output acr_admin_username

# Password (sensível)
terraform output -raw acr_admin_password

# Login server (URL do registry)
terraform output acr_login_server
```

### Via Azure CLI

```bash
# Username e senhas
az acr credential show --name acrtogglemasterprod

# Apenas o username
az acr credential show --name acrtogglemasterprod --query "username" -o tsv

# Apenas a primeira senha
az acr credential show --name acrtogglemasterprod --query "passwords[0].value" -o tsv

# Apenas a segunda senha
az acr credential show --name acrtogglemasterprod --query "passwords[1].value" -o tsv
```

### Renovar senha do ACR

```bash
# Regenerar a primeira senha
az acr credential renew --name acrtogglemasterprod --password-name password

# Regenerar a segunda senha
az acr credential renew --name acrtogglemasterprod --password-name password2
```

### Login no ACR via Docker

```bash
# Login com Azure CLI (recomendado)
az acr login --name acrtogglemasterprod

# Login com Docker usando credenciais admin
docker login acrtogglemasterprod.azurecr.io \
  -u $(az acr credential show --name acrtogglemasterprod --query "username" -o tsv) \
  -p $(az acr credential show --name acrtogglemasterprod --query "passwords[0].value" -o tsv)
```

### Configurar secrets no GitHub (para pipelines CI/CD)

```bash
# Definir ACR_USERNAME e ACR_PASSWORD como secrets nos repositórios
ACR_USER=$(az acr credential show --name acrtogglemasterprod --query "username" -o tsv)
ACR_PASS=$(az acr credential show --name acrtogglemasterprod --query "passwords[0].value" -o tsv)

# Para cada repositório de serviço
for repo in auth-service flag-service targeting-service evaluation-service analytics-service; do
  gh secret set ACR_USERNAME --body "$ACR_USER" --repo freitasleoalves/fiap-tc-3-$repo
  gh secret set ACR_PASSWORD --body "$ACR_PASS" --repo freitasleoalves/fiap-tc-3-$repo
done
```

---

## Outros comandos úteis

### Configurar kubectl para o AKS

```bash
# Via output do Terraform
$(terraform output -raw aks_kube_config_command)

# Via Azure CLI
az aks get-credentials --resource-group rg-togglemaster-prod --name aks-togglemaster-prod
```

### Obter senha inicial do ArgoCD

```bash
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d
```

### Connection strings dos bancos (quando deploy_databases = true)

```bash
# PostgreSQL
terraform output -raw postgres_auth_connection_string
terraform output -raw postgres_flags_connection_string
terraform output -raw postgres_targeting_connection_string

# Redis
terraform output -raw redis_connection_string

# Service Bus
terraform output -raw servicebus_connection_string

# Cosmos DB
terraform output -raw cosmosdb_connection_string
```

## Estrutura dos arquivos

```
├── main.tf           # Resource Group e locals
├── providers.tf      # Providers (azurerm, helm) e backend remoto
├── variables.tf      # Declaração de variáveis
├── outputs.tf        # Outputs (endpoints, credentials, connection strings)
├── network.tf        # VNet e Subnet
├── aks.tf            # AKS Cluster e ACR
├── argocd.tf         # ArgoCD (Helm release)
├── postgresql.tf     # PostgreSQL Flexible Servers
├── redis.tf          # Redis Cache
├── servicebus.tf     # Service Bus namespace e queue
├── cosmosdb.tf       # Cosmos DB account e table
├── terraform.tfvars  # Valores das variáveis (gitignored)
└── README.md
```
