# -*- encoding : utf-8 -*-
{ cy: { i18n: {plural: { keys: [:zero, :one, :two, :few, :many, :other], rule: lambda { |n| n == 0 ? :zero : n == 1 ? :one : n == 2 ? :two : n == 3 ? :few : n == 6 ? :many : :other } } } } }
