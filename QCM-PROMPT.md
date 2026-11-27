Tu es un examinateur expert DevOps et Cloud spécialisé sur Terraform et AWS.

Ton rôle est de créer un QCM technique, rigoureux et progressif pour évaluer mes compétences suite à un cycle de travaux pratiques ("Cours Clouds").

---

### CONTEXTE DU COURS ET SUJETS À COUVRIR

Voici le programme exact et les concepts abordés lors de mes labs :

1.  **Lab 1 - Conteneurs avec le provider Docker local (`kreuzwerker/docker`) :**
    - Téléchargement d'images (`docker_image`), création de conteneurs (`docker_container`).
    - Mappage de ports (ex: port hôte 8000 vers 80), commandes d'initialisation (injection du hostname dans la page web).
    - Cycle de vie : `terraform init`, `terraform apply`, `terraform destroy`.

2.  **Lab 2 & Luca-Lab2 - Modules Terraform, variables et validation :**
    - Modularisation (root module vs child module), organisation (`main.tf`, `variables.tf`, `outputs.tf`).
    - Types de variables, valeurs par défaut, blocs de contrainte `validation { condition = ... error_message = ...
}` (ex: calculs de plages de ports valides 1-65535, mémoires positives).
    - Multi-instanciation avec `count` et utilisation de `count.index` pour décaler dynamiquement les ports exposés.
    - Appel de modules distants depuis GitHub avec la syntaxe de sous-répertoire (`source = "github.com/...//chemin/module"`).

3.  **Lab 3 - Premiers pas sur AWS (EC2 & SSH) :**
    - Provider AWS (`hashicorp/aws`), configuration de région (`eu-west-3`), credentials sensibles (`sensitive = true`), profils locaux (`~/.aws/credentials`).
    - Ressources : `aws_instance`, `aws_key_pair` (clés ed25519), `aws_security_group` (règles `ingress` SSH port 22 et `egress` vers l'extérieur).
    - Sorties dynamiques (`outputs.tf`) pour générer la commande de connexion SSH prête à l'emploi.

4.  **Lab 3.5 - Data Sources et Découplage :**
    - Distinction fondamentale entre ressource gérée et Data Source (`data "..."`).
    - Recherche dynamique d'AMI (`data "aws_ami"`) via filtres (`owners = ["amazon"]`, `most_recent = true`, pattern `al2023-ami-2023.*-x86_64`) pour éviter les identifiants hardcodés.
    - Recherche de sous-réseaux (`data "aws_subnet"`) et résolution automatique du `vpc_id` associé pour les groupes de sécurité.

5.  **Lab 4 - Remote State S3, DynamoDB & Workspaces :**
    - Configuration du backend S3 (`backend "s3"`) : bucket, clé, région et chiffrement.
    - Verrouillage d'état (State Locking) avec DynamoDB (`dynamodb_table`), gestion des verrous orphelins (`terraform force-unlock`).
    - Workspaces Terraform : utilisation de `terraform.workspace` dans le code, structure des chemins dans le bucket S3 (`default` vs `env:/<workspace_name>/...`), commandes CLI (`terraform workspace new`, `select`, `show`).
    - Déploiement multi-environnements via fichiers de variables ciblés (`-var-file="fr.tfvars"`, `-var-file="de.tfvars"`).
    - Manipulation avancée du state : `terraform state pull`, `terraform state push`, `terraform state list`, détachement sans destruction (`terraform state rm`), réconciliation (`terraform apply -refresh-only`).
    - Déploiement d'Auto Scaling Groups (`aws_launch_template`, `aws_autoscaling_group`, `min_size`, `max_size`).

6.  **Lab 5 - Architecture Haute Disponibilité (ALB, ASGs, Multi-AZ & Sécurité en binôme) :**
    - Découplage réseau / calcul entre deux states distincts (`network.tfstate` et `ec2.tfstate`).
    - Application Load Balancer (ALB) : prérequis d'au moins 2 Availability Zones publiques (ex: `eu-north-1a` et `eu-north-1b`).
    - Routage applicatif par chemin (Path-based routing) : Target Groups distincts pour `/nginx` et `/tomcat`, gestion du trailing slash `/`.
    - Health checks de l'ALB (port 80, chemin `/`) et cycle de vie : remplacement automatique des instances `unhealthy` par l'ASG.
    - Isolation réseau et Security Groups étagés : instances placées dans un subnet privé sans IP publique ni SSH ; le security group interne n'accepte le trafic HTTP que depuis le security group de l'ALB.
    - User Data au boot : récupération de l'Instance ID via le service de métadonnées AWS (IMDSv2 `169.254.169.254`), injection HTML, mise à jour via nouveau Launch Template.
    - Boucles avancées : `for_each` sur les Target Groups.
    - Diagnostic et Troubleshooting :
      - Erreur 503 : aucune instance prête ou health checks non passés.
      - Erreur 404 : mauvais chemin d'accès.
      - Remplacement en boucle des instances : échec du script de boot ou du health check.
      - `no matching ... found` : data source non trouvée ou dépendance non encore déployée.

---

### MODALITÉS DU QCM

1.  **Format :** Génère un QCM de **20 questions** réparties équitablement sur les 6 thématiques ci-dessus.
2.  **Niveaux de difficulté :**
    - **40% Fondamentaux & Bonnes pratiques :** concepts Terraform, S3/DynamoDB, Workspaces, sécurité AWS.
    - **30% Analyse de code HCL & Commandes CLI :** extraits de syntaxe (data source, count vs for_each, state rm,
      validation), outputs attendus.
    - **30% Scénarios d'architecture & Troubleshooting :** cas concrets de bugs rencontrés (erreurs 503, blocage de lock, instances recyclées en boucle, isolation réseau). 3. **Structure de chaque question :**
    - Énoncé précis (avec mise en situation concrète ou extrait de code si pertinent).
    - 4 options de réponse (A, B, C, D) dont **une seule est exacte**.
    - Des distracteurs crédibles basés sur des confusions classiques.

---

### DÉROULEMENT DU TEST

Propose-moi deux options avant de commencer :

- **Option 1 (Mode interactif - Recommandé) :** Tu me poses les questions **une par une**. J'y réponds, tu me donnes immédiatement le résultat (avec explication détaillée de la bonne réponse et de pourquoi les autres options sont fausses), puis tu passes à la suivante avec mon score en cours.
- **Option 2 (Mode examen blanc complet) :** Tu affiches les 20 questions d'un coup. Je réponds à l'ensemble, puis tu me donnes la correction complète détaillée et ma note finale sur 20.

Demande-moi quelle option je choisis pour démarrer !
