# AWS CLI Usage

And other acronyms abound...

Have an AWS account with TACC, want to use the Command Line Interface (CLI).

1. If not done, first set up account a la TACC's guide
[here](https://frontera-portal.tacc.utexas.edu/user-guide/cloud/#amazon-web-services-aws).
    Make sure to set up Multi-Factor Authentication (MFA), e.g. with Duo App on
    phone. Also install CLI following their link provided.

2. Next steps describe more specifically what is outlined
   [here](https://aws.amazon.com/premiumsupport/knowledge-center/authenticate-mfa-cli/). Basically we need to set a up a temporary session every time we access AWS through the CLI, which involves getting some temporary keys.

3. Navigate to your account's "security credentials":
   [here](https://console.aws.amazon.com/iam/home?nc2=h_m_sc#/security_credentials).
    Grab the ARN (not even sure what that stands for) for your MFA device, e.g.
    something like:

    ```
    arn:aws:iam::<######>:mfa/<username>
    ```

4. On the machine where CLI is installed run:

    ```
    aws sts get-session-token --serial-number arn-of-the-mfa-device --token-code code-from-token --duration-seconds 129600
    ```

    where "arn-of-the-mfa-device" is replaced by the ARN from step 3 and
    "code-from-token" is from your MFA device (e.g. duo app).
    The `duration-seconds` argument is given 129600, i.e. 36 hours, the longest
    possible temporary session.

5. This outputs something like this:

    ```
    {
    "Credentials": {
        "SecretAccessKey": "secret-access-key",
        "SessionToken": "temporary-session-token",
        "Expiration": "expiration-date-time",
        "AccessKeyId": "access-key-id"
        }
    }
    ```
    Copy these to the file `~/.aws/credentials` as follows:

    ```
    [mfa]
    aws_access_key_id = example-access-key-as-in-returned-output
    aws_secret_access_key = example-secret-access-key-as-in-returned-output
    aws_session_token = example-session-Token-as-in-returned-output
    ```
    this can also be done with environment variables.

6. Use the CLI with the additional argument `--profile mfa`, e.g.

    ```
    aws s3 ls --profile mfa
    ```
