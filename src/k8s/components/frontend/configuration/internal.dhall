let Kubernetes/SecurityContext =
      https://raw.githubusercontent.com/dhall-lang/dhall-kubernetes/master/1.18/schemas/io.k8s.api.core.v1.SecurityContext.dhall sha256:ebd2dfc83e8a5bec031f3d71e9c5bf2ac583ab56572f8d7f3a8f9c9f113e3a0a

let Simple = (../../../../simple/frontend/package.dhall).Containers

let simpleFrontend = Simple.frontend

let sharedConfiguration = ./shared.dhall

let environment = ./environment/environment.dhall

let ContainerConfiguration =
      { Type =
            { securityContext : Optional Kubernetes/SecurityContext.Type }
          ⩓ sharedConfiguration.ContainerConfiguration.Type
      , default =
            { securityContext = None Kubernetes/SecurityContext.Type }
          ∧ sharedConfiguration.ContainerConfiguration.default
      }

let FrontendContainer =
      { Type = ContainerConfiguration.Type ⩓ { Environment : environment.Type }
      , default =
            ContainerConfiguration.default
          ⫽ { Environment = environment.default, image = simpleFrontend.image }
      }

let JaegerContainer =
      ContainerConfiguration
      with default.image = sharedConfiguration.JaegerImage

let Containers =
      { Type =
          { Frontend : FrontendContainer.Type, Jaeger : JaegerContainer.Type }
      , default =
        { Frontend = FrontendContainer.default
        , Jaeger = JaegerContainer.default
        }
      }

let Deployment =
      { Type = { Containers : Containers.Type }
      , default.Containers = Containers.default
      }

let configuration =
      { Type = { namespace : Optional Text, Deployment : Deployment.Type }
      , default = { namespace = None Text, Deployment = Deployment.default }
      }

in  configuration
