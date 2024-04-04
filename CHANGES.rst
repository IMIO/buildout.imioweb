CHANGELOG
=========

5.2.3-3 (unreleased)
--------------------

- Fix buildout : pinned setuptools = 62.4.0 and cryptography = 3.4
  [boulch]

- imioweb.core 1.0a4

    - WEB-4089 : Add recaptcha to contact-info form
      [boulch]

- Add collective.messagesviewlet (0.23)
  [boulch]
 
- collective.behavior.banner 1.3

    - Fix use of default_page
      [pbauer]


5.2.3-2 (2021-03-01)
--------------------

- collective.faceted.taxonomywidget 1.0a7

    - Ensure eea select2 resources is always loaded
      [laulaz]


5.2.3-1 (2021-01-11)
--------------------

- collective.anysurfer 1.4.2

    - Breadcrumb is already in a "div" in Plone4, so, we override plone.app.layout.viewlets.path_bar.pt. only for Plone5. 
      [boulch]

- iaweb.mosaic 1.0.0

    - MWEBIMI-25: Hide slides after the first one to improve page loading
      [mpeeters]
