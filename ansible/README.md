# Ansible layout (reusable & dynamic)

## Structure

- **group_vars/all.yml** – Shared vars: `client_name`, `client_environment`, `aws_region`, `aws_account_id`, `workspace_base`. Override via `--extra-vars` (e.g. from userdata).
- **group_vars/frontend.yml** – `ssm_parameters_to_fetch`, `app_workspace`, `ecr_image_var` for frontend.
- **group_vars/backend.yml** – Same for backend (only fetches the SSM params it needs).
- **playbooks/frontend-site.yml** – One play: common → frontend → ec2_tag_success.
- **playbooks/backend-site.yml** – One play: common → backend → ec2_tag_success.
- **tasks/ec2_tag_success.yml** – Shared task to tag EC2 after successful config.
- **roles/common** – Fetches SSM parameters (list from group_vars), sets `ssm_parameters` fact.
- **roles/docker** – Installs Docker and Docker Compose (used by frontend and backend).
- **roles/frontend** – Uses `ssm_parameters`, `app_workspace`; deploys frontend + nginx.
- **roles/backend** – Uses `ssm_parameters`, `app_workspace`; deploys backend stack.
- **library/ssm_params.py** – Dynamic SSM: key `internal_alb_dns` → path `/{client}/{env}/internal-alb-dns`. Add new params in group_vars only; no code change.

## Running

From userdata (node-bootstrap.sh):

```bash
ansible-playbook -i inventory/all.yml playbooks/<frontend|backend>-site.yml --limit <frontend|backend> \
  --extra-vars "client_name=... client_environment=... aws_region=... aws_account_id=..."
```

Locally (from repo root, with env or extra-vars):

```bash
cd ansible
export CLIENT_NAME=myclient CLIENT_ENVIRONMENT=prod AWS_REGION=eu-west-1 AWS_ACCOUNT_ID=123456789
ansible-playbook -i inventory/all.yml playbooks/frontend-site.yml --limit frontend
```

## Adding a new SSM parameter

1. Add the parameter in AWS SSM under `/{client_name}/{client_environment}/my-new-param` (use hyphens).
2. In `group_vars/frontend.yml` or `backend.yml`, add `my_new_param` to `ssm_parameters_to_fetch`.
3. Use `ssm_parameters.my_new_param` in templates or tasks. No change to `library/ssm_params.py`.
