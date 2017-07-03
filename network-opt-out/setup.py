from setuptools import setup, find_packages

setup(name='trubbish',
      version=1.0,
      description='Remove disabled jobs from jenkins',
      author='Jonathan Goodwin',
      author_email='jgoodwin@hubspot.com',
      url='http://product.hubspot.com/',
      packages=find_packages(),
      install_requires=['argparse',
                        'python-jenkins==0.4.8',
                        'requests[security]',
                        'hubspot_config>=1.0'],
      platforms=["any"],
      entry_points={
          'console_scripts': [
              'opt-out=opt_out:main',
          ]})


