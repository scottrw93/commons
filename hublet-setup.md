# hublet-setup

## Vault Secrets

- Create a new Keyczar signing key using [this script](https://git.hubteam.com/gist/jhaber/23e27cc23013279d309b94ed22700ca9) and add it to the new Hublet Vault under `hs-my-mount/my.key`
- Create a new token for vendor XYZ
  - Log into https://vendor.com using [these](https://ss.hubspotcentral.net/app/#/secrets/all) creds from secret server
  - Go to `Settings -> API -> New Token`
  - Name the token after the new Hublet and give it permissions A, B, and C
  - Add the token to the new Hublet Vault under `hs-my-mount/vendor.token`

## Config Overrides

- Update code to use `LoadBalancerDiscovery` so we can eliminate [this](https://private.hubteam.com/config/com.hubspot.tq2.api.client/Tq2ApiClientConfig/API_CLIENT_BASE_URL/STRING) config property

## Acceptance Tests

- Follow up on Gimmie issue #XYZ to see if we can migrate our ATs to Gimmie yet
- If not, create test portals in the new Hublet via Atlas
- Populate the expected state for the ATs
  - Hit this api-goggles with the new AT portalId: https://tools.hubteam.com/api/request/abc
  - Hit this api-goggles with the new AT portalId: https://tools.hubteam.com/api/request/def
  - Create config override for [this property](https://private.hubteam.com/config/com.hubspot.analytics.acceptancetests/AnalyticsAcceptanceTestsConfig/ACCEPTANCE_TEST_PORTAL/INTEGER) to point at new AT portalId
  - ....
