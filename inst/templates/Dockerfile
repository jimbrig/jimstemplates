FROM {{{base_image}}}

ARG R_CONFIG_ACTIVE={{{app_config}}}

{{{sysreqs}}}

COPY ./deps.R /tmp/deps.R

RUN Rscript /tmp/deps.R && rm -rf /tmp/*

# Copy app into `shiny_app` directory
COPY ./shiny_app /srv/shiny-server/shiny_app

# Update permissions (recursively) to App directory for `shiny` user
RUN chown -R shiny:shiny /srv/shiny-server/shiny_app

# Set the R_CONFIG_ACTIVE environment variable for Shiny.  For some reason shiny-server
# can't read in regular environment variables, so we have to pass the environment variable
# as a build argument to this Docker image, and then set it as an R environment variable. We
# set it in .Rprofile rather than .Renviron, because if there is a .Renviron supplied with the
# shiny app, the .Renviron from the shiny user's home folder will not be read in.
RUN echo "Sys.setenv(R_CONFIG_ACTIVE='$R_CONFIG_ACTIVE')" >> /home/shiny/.Rprofile

USER shiny

{{{additional_r_commands}}}

CMD ["/usr/bin/shiny-server"]
