consul_wrapper CHANGELOG
========================

This file is used to list changes made in each version of the consul_wrapper cookbook.

## 0.3.0

- [Kirill Kouznetsov] - change `node_exporter` & `postgres_exporter` service names in consul to `node-exporter` & `postgres-exporter` as underscores are unsupported by DNS.
- [Kirill Kouznetsov] - register consul http port as a consul service if it is exposed to somewhere other than loopback network.
- [Kirill Kouznetsov] - forced some more RuboCop rules, including trailing commas at the and of multiline hashes & lists for better diffs readability.
- [Kirill Kouznetsov] - removed some UFW rules; use external cookbook instead if you want more.


## 0.2.3

- [Kirill Kouznetsov] - Some basic Consul 1.0.0 support.

## 0.2.2

- [Kirill Kouznetsov] - Add firewall rules to open Consul ports

## 0.2.1

- [Kirill Kouznetsov] - private ip selection was refactored.
- [Kirill Kouznetsov] - serf_wan interface should be public.
- [Kirill Kouznetsov] - Elasticsearch service checks were refactored.
- [Kirill Kouznetsov] - Rails service http check was removed.
- [Kirill Kouznetsov] - New resource for postgresql prometheus exporter.

## 0.1.18

- [Kirill Kouznetsov] - Docker service resource.

## 0.1.17

- [Kirill Kouznetsov] - grep running rails processes by user id, not by user name.

## 0.1.16

- [Kirill Kouznetsov] - new resource for `postgres_exporter` service.
- [Kirill Kouznetsov] - add http checks for prometheus exporters.

## 0.1.15

- [Kirill Kouznetsov] - new resource for `node_exporter` service.
- [Kirill Kouznetsov] - refactored resources:
    * elasticsearch
    * memcached
    * postgresql
    * rails
    * redis
    * sidekiq

## 0.1.3

- [Kirill Kouznetsov] - check found chef nodes if designated consul network interface presents

## 0.1.2

- [Kirill Kouznetsov] - allow default recipe to be ran under Chef Solo for test purposes.

## 0.1.1

- [Kirill Kouznetsov] - resources/providers for rails appliation, elasticsearch, redis and postgresql were initially added instead of default recipes.

# 0.0.1

- [Maxim Filatov] - Initial release of consul_wrapper

- - -
Check the [Markdown Syntax Guide](http://daringfireball.net/projects/markdown/syntax) for help with Markdown.

The [Github Flavored Markdown page](http://github.github.com/github-flavored-markdown/) describes the differences between markdown on github and standard markdown.
