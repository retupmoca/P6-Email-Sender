role Email::Sender::Sendmail {
    method transport($email, :$envelope-from, :$envelope-to) {
        my $sm = run 'sendmail', '-f', $envelope-from, $envelope-to, :in;
        $sm.in.print: ~$email;
        $sm.in.close;
    }
}
