## Downloading an Install Kit

You can directly download InterSystems IRIS Community and InterSystems IRIS for Health Community from https://evaluation.intersystems.com/Eval/. You will need to sign in with an InterSystems single-sign-on window, if you do not already have an account you can create one for free.

![Evaluation.intersystems.com](Evaluation.png)

Once signed in, on the page you will see a link to the Community Edition. Click the Community Edition link to see the download options: 

![Evaluation.intersystems download page](EvaluationDownloadPage.png)

From here, choose whether you would like InterSystems IRIS Community or InterSystems IRIS For Health Community, then choose your operating system and the version (remember that license files will expire 1 year after release, so its recommended to choose the most recent).

Finally, accept Terms of Service and Privacy Statement, and then select Download to begin downloading the installation kit. 

For more information on the install, see the [platform specific installation guides in the documentation](https://docs.intersystems.com/irislatest/csp/docbook/DocBook.UI.Page.cls?KEY=PAGE_deployment_install)

### Unexpire passwords

By default, Community editions of IRIS health have the password SYS for every account, but these have expired, meaning you will be prompted to change the passwords on first login with the management portal. Authorization with other methods might fail due to an unexpired password. You can unexpire the passwords with the following command

```
set $NAMESPACE = "%SYS"
do ##class(Security.Users).UnExpireUserPasswords("*")
```

**This is only suitable for development and should not be used in production.**


