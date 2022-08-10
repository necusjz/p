---
title: Generate CLI from Swagger
abbrlink: 1507841079
date: 2022-04-08 10:21:45
tags: Azure
---
It's always good to start with a command like that:
```text
$ autorest --version=3.0.6370 --az --use=@autorest/az@latest ../azure-rest-api-specs/specification/dnsresolver/resource-manager/readme.md --azure-cli-extension-folder=./azure-cli-extensions
```

Make sure you have these specific versions installed:

| AutoRest Core  | AutoRest CLI  | Node.js  |
|:--------------:|:-------------:|:--------:|
|    3.0.6370    |     3.5.1     |  12.20   |

Errors you might encounter nowadays:
- ERROR: Schema violation: Additional properties not allowed: x-ms-identifiers
    1. Append *\-\-pass-thru:schema-validator-swagger* to the command;
- AttributeError: module 'mistune' has no attribute 'BlockGrammar'
    1. Active the venv within *~/.autorest/@autorest_python\@5.4.0/node_modules/@autorest/python*;
    2. Execute *pip install mistune==0.8.4*;
- ImportError: cannot import name '_unicodefun' from 'click'
    1. Active the venv within *~/.autorest/@autorest_az\@1.8.0/node_modules/@autorest/az*;
    2. Execute *pip install click==8.0.2*;

One more thing, it's a good practice to clean up AutoRest extensions by:
```text
$ autorest --reset
```
<!--more-->
When *readme.az.md* is missing, the header should be like:
~~~markdown
# AZ

These settings apply only when `--az` is specified on the command line.

``` yaml $(az)
az:
    extensions: dns-resolver
    namespace: azure.mgmt.dnsresolver
    package-name: azure-mgmt-dnsresolver
az-output-folder: $(azure-cli-extension-folder)/src/dns-resolver
python-sdk-output-folder: $(az-output-folder)/azext_logz/vendored_sdks/dnsresolver

# add additional configuration here specific for Azure CLI
# refer to the faq.md for more details
```
~~~

Make sure *azext_metadata.json* meets the demand:
```yaml
extension-mode: preview
```

From *report.md*, resolve the defects within UX:
```yaml
cli:
  cli-directive:
# rename command groups
    - where:
        group: DnsForwardingRulesets
      name: forwarding_rulesets
    - where:
        group: VirtualNetworkLinks
      name: vnet_links
# rename commands
    - where:
        group: DnsResolvers
        op: ListByVirtualNetwork
      name: list
    - where:
        group: DnsForwardingRulesets
        op: ListByVirtualNetwork
      name: list
```

Fix *azdev style* and *azdev linter* checks:
```yaml
cli:
  cli-directive:
# add alias to parameters
    - where:
        group: ForwardingRules
        parameter: dnsForwardingRulesetName
      alias:
        - ruleset_name
    - where:
        group: VirtualNetworkLinks
        parameter: dnsForwardingRulesetName
      alias:
        - ruleset_name
    - where:
        group: DnsForwardingRulesets
        op: CreateOrUpdate#Create
        parameter: dnsResolverOutboundEndpoints
      alias:
        - outbound_endpoints
```

Clean up tests folder and compose *test_dns_resolver_commands.py*:
```python
# --------------------------------------------------------------------------------------------
# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License. See License.txt in the project root for license information.
# --------------------------------------------------------------------------------------------

# pylint: disable=line-too-long
# pylint: disable=too-many-lines

from azure.cli.testsdk import (
    ResourceGroupPreparer,
    ScenarioTest
)


class DnsResolverClientTest(ScenarioTest):
    @ResourceGroupPreparer(name_prefix="cli_test_dns_resolver_", location="westus")
    def test_dns_resolver_crud(self):
        self.kwargs.update({
            "dns_resolver_name": self.create_random_name("dns-resolver-", 20),
            "vnet_name": self.create_random_name("vnet-", 12)
        })
        ...
```

Remaining work to be done:
- Update *README.rst* and *HISTORY.rst*;
- Update *CODEOWNERS* and *service_name.json*;
