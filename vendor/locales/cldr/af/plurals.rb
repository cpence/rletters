# -*- encoding : utf-8 -*-
{ :'af' => { i18n: { plural: { keys: [:one, :other], rule: lambda { |n| n == 1 ? :one : :other } } } } }
