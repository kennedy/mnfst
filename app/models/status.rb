require 'hkp'
require 'sig_exception'

class Status < ActiveRecord::Base
  belongs_to :key

  before_create :set_keyid, :set_hexid

  delegate :keyid, :formatted_keyid, to: :key

  def key_signer_count
    key.signers.count
  end

  def some_key_signers
    key.signers.limit(1)
  end

  def source_sig
    signed_body || signature
  end

  private

  def set_hexid
    self.hexid = SecureRandom.hex(4)
  end

  def set_keyid
    self.body, raw_key = verify
    self.key = Key.find_or_create_by(keyid: raw_key.primary_subkey.keyid)
    self.key.update(primary_name: raw_key.primary_uid.name, primary_email: raw_key.primary_uid.email)
  rescue ActiveRecord::ActiveRecordError => e
    self.error.add(e.message)
    false
  rescue GPGME::Error::NoData
    self.errors.add(:signed_body, "Invalid signature")
    false
  end

  def verify(tries = 2)
    sig = nil

    if self.body.present? && self.signature.present?
      crypto.verify(self.signature, signed_text: self.body) { | sig_ | sig = sig_ }
      verified_data(StringIO.new(body), sig, tries)
    else
      data = crypto.verify(signed_body){ | sig_ | sig = sig_ }
      verified_data(data, sig, tries)
    end
  end

  def verified_data(data, sig, tries)
    case GPGME.gpgme_err_code(sig.status)
    when GPGME::GPG_ERR_NO_ERROR
      [data.read, sig.key]
    when GPGME::GPG_ERR_NO_PUBKEY
      if tries > 0
        import_into_keyring(sig.fpr)
        verify(tries - 1)
      else
        raise SigException, "could not find public key for: #{sig.fpr}"
      end
    else
      raise SigException, sig.to_s
    end
  end

  def crypto
    GPGME::Crypto.new
  end

  def import_into_keyring(fingerprint)
    raw_pub_key = hkp.fetch(fingerprint)
    GPGME::Key.import(raw_pub_key)
  end

  def hkp
    Hkp.new(KEYSERVER_URL)
  end
end
