# frozen_string_literal: true

describe Property do
  def test_storage(objects)
    objects.each_with_index do |obj, idx|
      Property.put("prop_test_#{idx}", obj)
    end

    objects.each_with_index do |obj, idx|
      property = Property.get("prop_test_#{idx}")
      expect(property).to eq(obj)
    end
  end

  it 'storage basic types' do
    test_storage([
      1,
      'string',
      { hash: 1 },
      OpenStruct.new(hash: 1),
      { hash: { hash: 1 } }
    ])
  end 

  it 'error in mongoid types' do
    expect do
      test_storage([
        Property.new(key: 'test', value: 'test')
      ])
    end.to raise_error(Psych::DisallowedClass)
  end
end
