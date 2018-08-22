# frozen_string_literal: true

describe do
  it 'validate_graphql_schema' do
    result = GuardianSchema.execute(
      '{ village {x , y}}',
      variables: {},
      context: { current_user: nil }
      ).to_json
    puts result
  end
end
