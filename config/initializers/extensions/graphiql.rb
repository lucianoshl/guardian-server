# https://github.com/rmosolgo/graphiql-rails/issues/43
module GraphiQL
  module Rails
    class EditorsController < ActionController::Base
      def show
        render file: 'graphiql/rails/editors/show'
      end
    end
  end
end
