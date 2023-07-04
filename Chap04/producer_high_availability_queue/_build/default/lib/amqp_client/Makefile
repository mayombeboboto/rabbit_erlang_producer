PROJECT = amqp_client
PROJECT_DESCRIPTION = RabbitMQ AMQP Client
PROJECT_MOD = amqp_client
PROJECT_REGISTERED = amqp_sup

define PROJECT_ENV
[
    {prefer_ipv6, false},
    {ssl_options, []},
    {writer_gc_threshold, 1000000000}
]
endef

define PROJECT_APP_EXTRA_KEYS
%% Hex.pm package informations.
	{licenses, ["MPL-2.0"]},
	{links, [
	    {"Website", "https://www.rabbitmq.com/"},
	    {"GitHub", "https://github.com/rabbitmq/rabbitmq-server/tree/main/deps/amqp_client"},
	    {"User guide", "https://www.rabbitmq.com/erlang-client-user-guide.html"}
	  ]},
	{build_tools, ["make", "rebar3"]},
	{files, [
	    $(RABBITMQ_HEXPM_DEFAULT_FILES)
	  ]}
endef

define HEX_TARBALL_EXTRA_METADATA
#{
	licenses => [<<"MPL-2.0">>],
	links => #{
		<<"Website">> => <<"https://www.rabbitmq.com">>,
		<<"GitHub">> => <<"https://github.com/rabbitmq/rabbitmq-server/tree/main/deps/amqp_client">>,
		<<"User guide">> => <<"https://www.rabbitmq.com/erlang-client-user-guide.html">>
	}
}
endef

# Release artifacts are put in $(PACKAGES_DIR).
PACKAGES_DIR ?= $(abspath PACKAGES)

LOCAL_DEPS = xmerl
DEPS = rabbit_common
TEST_DEPS = rabbitmq_ct_helpers rabbit meck

DEP_EARLY_PLUGINS = rabbit_common/mk/rabbitmq-early-test.mk
DEP_PLUGINS = rabbit_common/mk/rabbitmq-build.mk \
	      rabbit_common/mk/rabbitmq-hexpm.mk \
	      rabbit_common/mk/rabbitmq-dist.mk \
	      rabbit_common/mk/rabbitmq-run.mk \
	      rabbit_common/mk/rabbitmq-test.mk \
	      rabbit_common/mk/rabbitmq-tools.mk

PLT_APPS = ssl public_key

include rabbitmq-components.mk
include erlang.mk

HEX_TARBALL_FILES += rabbitmq-components.mk \
		     git-revisions.txt
