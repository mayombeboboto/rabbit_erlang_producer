{application,producer,
             [{description,"An OTP application"},
              {vsn,"0.1.0"},
              {registered,[]},
              {mod,{producer_app,[]}},
              {applications,[kernel,stdlib,sasl,amqp_client]},
              {env,[]},
              {modules,[producer,producer_app,producer_sup]},
              {licenses,["Apache-2.0"]},
              {links,[]}]}.