import { InlineNotification } from '@carbon/react';

/** MANDATORY synthetic-data disclaimer shown on every page. */
export default function DemoBanner() {
  return (
    <div className="demo-banner">
      <InlineNotification
        kind="info"
        lowContrast
        hideCloseButton
        title="Demonstration Environment"
        subtitle="All data is synthetic. No real client data or PII is used. Resumes are processed in memory and never stored."
      />
    </div>
  );
}
