use Email::MIME;

class Email::Sender {
    has %.options;

    method new(:$transport = 'Sendmail', *%options) {
        my $found = False;
        my $t;
        try {
            $t = (require ::('Email::Sender::'~$transport));
            $found = True;
        };
        try {
            $t = (require ::($transport));
            $found = True;
        };
        die 'Unable to find transport implementation: '~$transport unless $found;

        my $s = self.bless(:%options);
        $s does $t;
    }

    multi method send(Email::Simple $email) {
        self.transport($email);
    }

    multi method send(Str $email) {
        self.send: Email::Simple.new($email);
    }

    multi method send(*%mailstuff) {
        self.send: self.create(|%mailstuff);
    }

    method create(:$to!, :$from!, :$subject!, :$text-body!, :$html-body, :@attachments) {
        my $message = Email::MIME.create(attributes => { content-type => 'text/plain',
                                                         charset      => 'utf-8',
                                                         encoding     => 'quoted-printable' },
                                         body-str   => $text-body);
        if $html-body {
            my $html-message = Email::MIME.create(attributes => { content-type => 'text/html',
                                                                  charset      => 'utf-8',
                                                                  encoding     => 'quoted-printable' },
                                                  body-str   => $html-body);

            $message = Email::MIME.create(attributes => { content-type => 'multipart/alternative' },
                                          parts      => ($message,
                                                         $html-message),
                                          body       => 'This is a multipart message in MIME format.');
        }

        if @attachments {

        }

        $message.header-str-set('To',      $to);
        $message.header-str-set('From',    $from);
        $message.header-str-set('Subject', $subject);

        $message;
    }

    method transport($email) {
        ... # implemented by transport roles
    }
}
