#!/usr/bin/env python3
# Dynamic SSM lookup: parameter key (e.g. internal_alb_dns) -> path /{client_name}/{client_environment}/internal-alb-dns

from ansible.module_utils.basic import AnsibleModule
import boto3


def key_to_ssm_path(client_name, client_environment, key):
    """Convert parameter key to SSM path: internal_alb_dns -> /{client}/{env}/internal-alb-dns"""
    segment = key.replace("_", "-")
    return f"/{client_name}/{client_environment}/{segment}"


def main():
    module = AnsibleModule(
        argument_spec=dict(
            client_name=dict(required=True, type="str"),
            client_environment=dict(required=True, type="str"),
            region=dict(required=False, type="str", default="eu-west-1"),
            parameters=dict(required=True, type="list", elements="str"),
        )
    )

    client_name = module.params["client_name"]
    client_environment = module.params["client_environment"]
    region = module.params["region"]
    parameters = module.params["parameters"]

    try:
        ssm = boto3.client("ssm", region_name=region)
        results = {}

        for key in parameters:
            param_name = key_to_ssm_path(client_name, client_environment, key)
            response = ssm.get_parameter(Name=param_name)
            results[key] = response["Parameter"]["Value"]

        module.exit_json(changed=False, ansible_facts=dict(ssm_parameters=results))

    except Exception as e:
        module.fail_json(msg="Error retrieving SSM parameters: %s" % str(e))


if __name__ == "__main__":
    main()
