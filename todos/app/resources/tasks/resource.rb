# frozen_string_literal: true

module Tasks
  class Resource < ApplicationResource
    filter_by :list
    sort_by :sorting
  end
end
