# frozen_string_literal: true

describe do
  it 'validate_graphql_schema' do
    result = GuardianSchema.execute(
      %{{
          village(id: 45649) {
            status
            next_event
            reports {
              dot
              ocurrence
              pillage {
                wood
                stone
                iron
              }
              resources {
                wood
                stone
                iron
              }
            }
          }
        }},
        variables: {},
        context: { current_user: nil }
        )
    pp result.to_h
    expect(result.to_h['errors']).to be_nil
  end
end
