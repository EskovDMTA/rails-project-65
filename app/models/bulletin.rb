# frozen_string_literal: true

class Bulletin < ApplicationRecord
  include AASM
  include ActionView::Helpers::DateHelper

  mount_uploader :image, BulletinUploader

  belongs_to :user, inverse_of: :bulletins, optional: false
  belongs_to :category, inverse_of: :bulletins, optional: false

  validates :title, :description, :image, presence: true

  aasm column: 'state' do
    state :draft, initial: true
    state :under_moderation
    state :published
    state :rejected
    state :archived

    event :submit_for_moderation do
      transitions from: :draft, to: :under_moderation
    end

    event :approve do
      transitions from: :under_moderation, to: :published
    end

    event :reject do
      transitions from: %i[draft under_moderation], to: :rejected
    end

    event :archive do
      transitions to: :archived
    end
  end

  def self.ransackable_associations(_auth_object = nil)
    %w[category image_attachment image_blob user]
  end

  def self.ransackable_attributes(_auth_object = nil)
    %w[state title category]
  end

  def formatted_created_at
    created_at.strftime('%d %B %Y')
  end

  def time_ago
    time_ago_in_words(created_at)
  end

  def self.states
    @states ||= aasm.states.map(&:name)
  end

  def self.state_options
    {
      'Черновик' => 'draft',
      'На модерации' => 'under_moderation',
      'Опубликовано' => 'published',
      'Возвращено' => 'rejected',
      'В архиве' => 'archived'
    }
  end

  def state_label
    case state.to_sym
    when :draft
      'Черновик'
    when :under_moderation
      'На модерации'
    when :published
      'Опубликовано'
    when :rejected
      'Возвращено'
    when :archived
      'В архиве'
    else
      'Unknown'
    end
  end
end
