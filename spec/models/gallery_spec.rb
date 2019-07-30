# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Gallery, type: :model do
  let(:null_values) do
    [
      nil,
      '',
      ' ',
      '                       '
    ]
  end

  it 'is valid with valid attributes' do
    gallery = build(:gallery)
    expect(gallery).to be_valid
  end

  describe Gallery, '#name' do
    let(:valid_names) do
      [
        '2018 trip to Paris',
        "Sally's birthday",
        'emily@example.com',
        'abc',
        '~&^U}@N% ^Y$TC£$}%R$V$^£"',
        'ȍ\򂡌ŽX/ٸǢʐՉ䄥y񡲠ذꐛٯ佶�˹ש;E繠'
      ]
    end

    it 'accepts valid names' do
      valid_names.each do |value|
        gallery = build(:gallery, name: value)
        expect(gallery.name).to eq value
        expect(gallery).to be_valid
      end
    end

    it 'is present' do
      null_values.each do |value|
        gallery = build(:gallery, name: value)
        expect(gallery).to_not be_valid
      end
    end

    it 'is no longer than 50 characters' do
      value = 'a' * 49
      gallery = build(:gallery, name: value)
      expect(gallery).to be_valid

      value = 'b' * 50
      gallery = build(:gallery, name: value)
      expect(gallery).to be_valid

      value = 'c' * 51
      gallery = build(:gallery, name: value)
      expect(gallery).to_not be_valid
    end

    it 'is no shorter than 3 characters' do
      value = 'a' * 4
      gallery = build(:gallery, name: value)
      expect(gallery).to be_valid

      value = 'b' * 3
      gallery = build(:gallery, name: value)
      expect(gallery).to be_valid

      value = 'c' * 2
      gallery = build(:gallery, name: value)
      expect(gallery).to_not be_valid
    end
  end

  describe Gallery, '#description' do
    let(:valid_descriptions) do
      [
        "Louvre, Musée d'Orsay and Arc de Triomphe",
        'Best night ever! 22/06/2019 @ The Red Lion.',
        'Taken by Philip Lowther Photography, York',
        'gallery@foo.com',
        '',
        nil
      ]
    end

    it 'accepts valid descriptions' do
      valid_descriptions.each do |value|
        gallery = build(:gallery, description: value)
        expect(gallery.description).to eq value
        expect(gallery).to be_valid
      end
    end

    it 'is no longer than 255 characters' do
      value = 'a' * 254
      gallery = build(:gallery, description: value)
      expect(gallery).to be_valid

      value = 'b' * 255
      gallery = build(:gallery, description: value)
      expect(gallery).to be_valid

      value = 'c' * 256
      gallery = build(:gallery, description: value)
      expect(gallery).to_not be_valid
    end
  end
end
