# -*- encoding : utf-8 -*-
{ rm: { i18n: {plural: { keys: [:one, :other], rule: lambda { |n| n == 1 ? :one : :other } } } } }
