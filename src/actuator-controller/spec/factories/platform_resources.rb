# frozen_string_literal: true

# Defines factories for creating PlatformResource objects
FactoryGirl.define do
  # Abstract factory for PlatformResource
  factory :platform_resource do
    # Factory with not all necessary attributes
    factory :missing_args do
      uuid 'ab631116-2837-11e6-b67b-9e71128cae77'
      status 'on'

      # Factory with an on purpose attribute typo
      factory :typo do
        collect_intervallllll 60
      end

      factory :resource_default_2 do
        uuid '9f77c561-3046-4363-87c4-6a4cc3c61c6e'
      end
      # Resource with all necessary attributes
      factory :essential_args do
        # Factory with 'capabilities' as an empty array
        factory :empty_capability do
          capabilities []
        end

        # Factory with 'capabilities' as a valid array
        factory :with_capability do
          capabilities %w['temperature weight luminosity']
        end

        factory :with_similar_capability do
          capabilities %w['temperature luminosity']
        end

        factory :with_more_capability do
          capabilities %w['temperature luminosity movement
                          radioactivity speed']
        end

        # Factory with 'capabilities' as a valid array
        factory :with_capability_second do
          capabilities %w['humidity pressure']
        end
      end
    end
  end
end
