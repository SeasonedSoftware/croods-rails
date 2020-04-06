# frozen_string_literal: true

module Tasks
  class Resource < ApplicationResource
    filter_by :list
    sort_by :sorting

    request do
      remove_attribute :finished
    end

    add_action :finish, method: :put do
      authorize member
      member.update!(finished: true)
      render json: member
    end
  end
end
