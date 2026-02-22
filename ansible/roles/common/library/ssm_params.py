#!/usr/bin/env python3

from ansible.module_utils.basic import AnsibleModule
import boto3
import json

def main():
    module = AnsibleModule(
        argument_spec=dict(
            client_name=dict(required=True, type='str'),
            client_environment=dict(required=True, type='str'),
            region=dict(required=False, type='str', default='eu-west-1'),
            parameters=dict(required=False, type='list', default=['internal_alb_dns', 'ecr_frontend_image', 'ecr_backend_image'])
        )
    )

    client_name = module.params['client_name']
    client_environment = module.params['client_environment']
    region = module.params['region']
    parameters = module.params['parameters']
    
    try:
        ssm = boto3.client('ssm', region_name=region)
        results = {}
        
        for param in parameters:
            if param == 'internal_alb_dns':
                param_name = f"/{client_name}/{client_environment}/internal-alb-dns"
            elif param == 'ecr_frontend_image':
                param_name = f"/{client_name}/{client_environment}/ecr-frontend-image"
            elif param == 'ecr_backend_image':
                param_name = f"/{client_name}/{client_environment}/ecr-backend-image"
            else:
                continue
                
            response = ssm.get_parameter(Name=param_name)
            results[param] = response['Parameter']['Value']
        
        module.exit_json(changed=False, ansible_facts=dict(ssm_parameters=results))
        
    except Exception as e:
        module.fail_json(msg=f"Error retrieving SSM parameters: {str(e)}")

if __name__ == '__main__':
    main()
