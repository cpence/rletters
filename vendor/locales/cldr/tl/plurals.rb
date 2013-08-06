# -*- encoding : utf-8 -*-
{ :'fil' => { i18n: { plural: { keys: [:one, :other], rule: lambda { |n| [0, 1].include?(n) ? :one : :other } } } } }
