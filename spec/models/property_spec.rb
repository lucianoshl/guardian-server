# frozen_string_literal: true

describe Property do
  it 'storage types' do
    objects = [
      1,
      'string',
      {hash: 1},
      OpenStruct.new({hash: 1}),
      {hash: {hash: 1}}
    ]

    objects.each_with_index do |obj, idx|
      Property.put("prop_test_#{idx}", obj)
    end

    objects.each_with_index do |obj, idx|
      property = Property.get("prop_test_#{idx}")
      expect(property).to be(obj)
    end
  end
end
