# AMWA IS-04 NMOS Discovery and Registration Specification

[![Lint Status](https://github.com/AMWA-TV/nmos-discovery-registration/workflows/Lint/badge.svg)](https://github.com/AMWA-TV/nmos-discovery-registration/actions?query=workflow%3ALint)
[![Render Status](https://github.com/AMWA-TV/nmos-discovery-registration/workflows/Render/badge.svg)](https://github.com/AMWA-TV/nmos-discovery-registration/actions?query=workflow%3ARender)

<!-- INTRO-START -->

## What does it do?

- Allows control and monitoring applications to find the resources on a network
  - Resources include Nodes, Devices, Senders, Receivers, Sources, Flows...

## Why does it matter?

- Enables automation and reduces manual overhead in setting up networked sytems
- Essential for dynamic deployment

## How does it work?

- Media Nodes locate IS-04 registry using DNS-SD (unicast preferred)
- Media Nodes register their resource information with HTTP + JSON
- Applications query with HTTP and/or subscribe with WebSocket

<!-- INTRO-END -->

## Getting started

There is more information about the NMOS Specifications and their GitHub repos at <https://specs.amwa.tv/nmos>.
