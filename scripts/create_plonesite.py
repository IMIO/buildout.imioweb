# -*- coding: utf-8 -*-
from AccessControl.SecurityManagement import newSecurityManager
from AccessControl.SecurityManagement import noSecurityManager
from Testing import makerequest
from zope.component.hooks import setSite
from zope.globalrequest import setRequest

import logging
import os
import transaction

logger = logging.getLogger("create.plonesite")


def main(app, site_id):
    default_language = "fr"
    app = makerequest.makerequest(app)
    # support plone.subrequest
    app.REQUEST["PARENTS"] = [app]
    setRequest(app.REQUEST)
    container = app.unrestrictedTraverse("/")

    acl_users = app.acl_users
    user = acl_users.getUser("admin")
    if user:
        user = user.__of__(acl_users)
        newSecurityManager(None, user)
        logger.info("Retrieved the admin user")

    # install plone site
    oids = container.objectIds()
    if site_id not in oids:
        # create plone site
        from Products.CMFPlone.factory import addPloneSite

        policy_profile = os.environ.get(
            "POLICY_PROFILE", "plone.app.contenttypes:plone-content"
        )
        extension_profiles = (policy_profile,)
        addPloneSite(
            container,
            site_id,
            title="Site de {0}".format(site_id),
            extension_ids=extension_profiles,
            setup_content=False,
            default_language=default_language,
        )

        transaction.commit()
        logger.info("Added Plone Site: {0}".format(site_id))
        plone = getattr(container, site_id)
        setSite(plone)

    else:
        logger.warning("A Plone Site liege already exists and will not be replaced")

    # install cputils
    # if not getattr(app, "cputils_install", None):
    #     from Products.ExternalMethod.ExternalMethod import manage_addExternalMethod

    #     manage_addExternalMethod(app, "cputils_install", "", "CPUtils.utils", "install")
    #     app.cputils_install(app)
    #     logger.info("Cpskin installed")
    transaction.commit()
    noSecurityManager()

    # update zope password
    users = app.acl_users.users
    admin_password = os.environ.get("admin_password", "admin")
    users.updateUserPassword("admin", admin_password)
    logger.info("Admin password updated")
    transaction.commit()


if __name__ == "__main__":
    site_id = os.environ.get("SITE_ID", "plone")
    main(app, site_id)  # noqa
